program matrixvector
implicit none

integer :: ierror, n[*], m[*], portion[*], summ[*], i, j, k, tmp, tmp2
integer, dimension(50,50), codimension[*]::a
integer, dimension(50), codimension[*]::b
logical :: init

call MPI_Initialized(init, ierror)
if(.not. init) then
    call MPI_Init(ierror)
endif

if (this_image()==1) then
    open(1,file='input.txt')
    read(1, *) n, m
    do i = 2, num_images()
        n[i] = n
        m[i] = m
    enddo
    !allocate(a(n,m))
    !allocate(b(n))
    do i=1, n
        read(1, *) (a(i,j), j=1,m)
    enddo
!    read(1, *) ((a(i:j), i=1,n) j=1, m)
!    do i=1, n
!        read(1) (a(i:j), j=1,m)
!    enddo
    read(1, *) (b(i), i=1,n)
endif

sync all

!if(this_image() .NE. 1) then
!    allocate(a(n, m)) ! m is too much!
!    allocate(b(n))
!endif

sync all

if(this_image()==1) then
    portion = m/num_images()
    tmp = portion
    do i = 2, num_images()-1
        portion[i] = portion
        do j = tmp+1, tmp+portion
        do k = 1, n
                a(k,j-tmp)[i] = a(k, j)
            enddo
        enddo
        tmp = tmp + portion
    enddo
    if(num_images() .NE. 1) then
        print *, tmp
        portion[num_images()] = m-tmp
        do j = tmp+1, m
            do k=1,n
                a(k,j-tmp)[num_images()] = a(k,j)
            enddo
        enddo
    endif
    do i=2,num_images()
        do j=1, n
            b(j)[i]= b(j)
        enddo
    enddo
endif
sync all


!if(this_image() == 1) then
!    do k=1, num_images()
!        print *, portion[k]
!        do i = 1, portion[k]
!            write (*, *) (a(j, i)[k], j=1, n)
!        enddo
!        write(*, *) (b(j)[k], j=1,n)
!        print *, "~~~~~"
!    enddo
!endif
summ = 0
do i=1, portion
   do j=1, n
        summ = summ + a(j,i)*b(j)
   enddo
enddo
print *, this_image(), summ
sync all
if(this_image() == 1) then
    do i=2, num_images()
        summ = summ+summ[i]
    enddo
    print*, summ
endif


!print *,n, m
!write(*,*) (b(i), i=1,n)
!if(this_image()==1) then
!    do i=1, n
!        print *, (a(i, j), j=1, m)
!    enddo
!endif
!deallocate(a)
!deallocate(b)
end program matrixvector